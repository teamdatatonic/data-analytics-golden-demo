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
# Provider with service account impersonation
####################################################################################
terraform {
  required_providers {
    google = {
      source                = "hashicorp/google-beta"
      version               = "4.42.0"
      configuration_aliases = [google.service_principal_impersonation]
    }
  }
}

# Provider that uses service account impersonation (best practice - no exported secret keys to local computers)
provider "google" {
  alias                       = "service_principal_impersonation"
  impersonate_service_account = var.impersonate_service_account
  project                     = var.project_id
}


####################################################################################
# Deployment Specific Resources (typically you customize this)
####################################################################################
locals {
  workflow_content = templatefile("../../workflows/terraform_bigquery_dataform_execute.yaml",
    {
      project_id = var.project_id
      region     = var.workflow_region
    })
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_iam_binding" "project_gcs_eventarc_binding" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com"
  ]

  depends_on = [google_project_service.eventarc, google_project_service.workflows]
}

resource "google_workflows_workflow" "sample-workflow-dataform" {
  name            = var.workflow_name
  region          = var.workflow_region
  project         = var.project_id
  description     = ""
  source_contents = local.workflow_content

  depends_on = [google_project_service.workflows]
}

resource "google_eventarc_trigger" "trigger-gcs-tf" {
  name            = "trigger-gcs-workflow-tf"
  location        = var.workflow_region
  project         = var.project_id
  service_account = var.impersonate_service_account

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  matching_criteria {
    attribute = "bucket"
    value     = var.workflow_trigger_bucket
  }

  destination {
    workflow = google_workflows_workflow.sample-workflow-dataform.id
  }

  depends_on = [
    google_project_iam_binding.project_gcs_eventarc_binding,
    google_workflows_workflow.sample-workflow-dataform
  ]
}
