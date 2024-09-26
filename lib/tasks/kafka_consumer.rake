namespace :kafka do
  desc 'Process images from Kafka'
  task process_images: :environment do
    consumer = ImageResizerConsumer.new
    consumer.run
  end
end
