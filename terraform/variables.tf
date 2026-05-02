variable "region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "ap-south-1"
}
variable "project_name" {
    description = "Security for Fundamentals Project"
    default = "cloud-security-project"
}
variable "bucket_name" {
  default = "rahul-cloudtrail-logs-unique-02052026"
}
