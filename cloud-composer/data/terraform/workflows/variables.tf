####################################################################################
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####################################################################################
# YouTube: https://youtu.be/2Qu29_hR2Z0


####################################################################################
# Common Variables (typically always required)
####################################################################################
variable "project_id" {
  type        = string
  description = "The current project"
  validation {
    condition     = length(var.project_id) > 0
    error_message = "The project_id is required."
  }
}

variable "impersonate_service_account" {
  type        = string
  description = "We want to impersonate the Terraform service account"
  default     = ""
  validation {
    condition     = length(var.impersonate_service_account) > 0
    error_message = "The impersonate_service_account is required."
  }
}


####################################################################################
# Deployment Specific Variables (typically you customize this)
####################################################################################
variable "project_number" {
  type = string
  default = "The gcs_agent_account"
  validation {
    condition = length(var.project_number) > 0
    error_message = "The gcs_agent_account is required"
  }
}

variable "workflow_name" {
  type        = string
  description = "The workflow_name"
  validation {
    condition     = length(var.workflow_name) > 0
    error_message = "The workflow_name is required."
  }
}

variable "workflow_region" {
  type        = string
  description = "The workflow_region"
  validation {
    condition     = length(var.workflow_region) > 0
    error_message = "The workflow_region is required."
  }
}

variable "workflow_trigger_bucket" {
  type = string
  description = "The workflow_trigger_bucket"
  validation {
    condition = length(var.workflow_trigger_bucket) > 0
    error_message = "The workflow_trigger_bucket is required"
  }
}
