require 'rdkafka'

$kafka = Rdkafka::Config.new(
  'bootstrap.servers' => ENV['KAFKA_BROKERS']
)