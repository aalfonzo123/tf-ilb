variable "network" {
  type = object({
    project-id      = string
    vpc-name        = string
    subnetwork-name = string
    region          = string
  })
}

variable "ilb-zones" {
  type = list(string)
}

variable "source-image" {

}