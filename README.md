﻿# Grafana Web App with PostgreSQL on Azure

This repository contains the necessary configuration files to deploy a containerized Grafana application with a PostgreSQL database on Azure.

## Why?

- Because it costs less than a Managed Grafana instance.
- Because by default you get an SQLite holding your configurations and it gets lost once the container is restarted. With an external Postgresql your configuration goes nowhere.

## Overview

The main configuration is defined in the `main.arm.json` file. This file is a JSON representation of an Azure Resource Manager (ARM) template generated by Bicep, a domain-specific language (DSL) for deploying Azure resources declaratively.

The template deploys the following resources:

- A resource group
- A Key Vault to store secrets
- A PostgreSQL (B1ms) server with a firewall rule and a database
- An App Service Plan (B1) and a Web App for the Grafana application
- Costs **~28USD**/month if you deploy it as is

## Parameters

The template requires several parameters to be provided:

- `location`: The Azure region where the resources will be deployed.
- `name`: A base name used to create unique names for the resources.
- `env`: An environment tag.
- `psqlAdminPassword`: The password for the PostgreSQL admin account.
- `grafanaAdminPassword`: The password for the Grafana admin account.
- `kvSecretsOwnerId`: The object ID of the user or service principal that will have access to the secrets in the Key Vault.

## Deployment

To deploy the resources, you can use the Azure CLI, PowerShell, or the Azure portal, and provide the necessary parameters.

Please note that this is a high-level explanation based on the available information. For a more accurate understanding, you might want to look at the code or contact the repository owner directly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms of the MIT license.
