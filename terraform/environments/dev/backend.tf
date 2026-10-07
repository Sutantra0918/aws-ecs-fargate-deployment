terraform {
  backend "s3" {

    bucket       = "taskflow-451664151915-ap-south-1"
    key          = "taskflow/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

