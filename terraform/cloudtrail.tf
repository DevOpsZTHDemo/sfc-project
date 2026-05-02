resource "aws_cloudtrail" "trail" {
    name = "IAM_Audit-Trail"
    s3_bucket_name = aws_s3_bucket.trail_bucket.id
    include_global_service_events = true
    is_multi_region_trail = true
}