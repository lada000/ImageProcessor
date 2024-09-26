class ImageResizerConsumer
  def initialize
    consumer_config = {
      'bootstrap.servers' => ENV['KAFKA_BROKERS'],
      'group.id' => 'image_processor_group'
    }
    kafka_consumer = Rdkafka::Config.new(consumer_config)
    @consumer = kafka_consumer.consumer
    @consumer.subscribe('images')
  end

  def run
    @consumer.each do |message|
      begin
        data = JSON.parse(message.payload)
        image_id = data['image_id']
        s3_key = data['s3_key']

        process_image(image_id, s3_key)
      rescue => e
        puts "Error processing message: #{e.message}"
      end
    end
  end

  private

  def process_image(image_id, s3_key)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['AWS_S3_BUCKET'])
    obj = bucket.object(s3_key)

    Tempfile.open(['original', File.extname(s3_key)]) do |file|
      obj.get(response_target: file.path)

      sizes = {
        'small' => [100, 100],
        'medium' => [500, 500],
        'large' => [1000, 1000]
      }

      resized_keys = {}

      sizes.each do |size_name, dimensions|
        resized_file = resize_image(file.path, dimensions)
        resized_key = "#{size_name}/#{SecureRandom.uuid}_#{File.basename(s3_key)}"

        bucket.object(resized_key).put(body: File.read(resized_file.path))

        resized_keys["#{size_name}_key"] = resized_key

        resized_file.close
        resized_file.unlink
      end

      producer = $kafka.producer
      payload = {
        image_id: image_id,
        **resized_keys
      }.to_json
      producer.produce(payload: payload, topic: 'processed_images').delivery_handle.wait
    end
  end

  def resize_image(path, dimensions)
    resized_file = Tempfile.new(['resized', File.extname(path)])
    image = MiniMagick::Image.open(path)
    image.resize "#{dimensions[0]}x#{dimensions[1]}"
    image.write resized_file.path
    resized_file
  end
end
