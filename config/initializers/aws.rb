require 'aws-sdk-s3'

Aws.config.update(
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
  endpoint: ENV['AWS_S3_ENDPOINT'],
  force_path_style: true
)
