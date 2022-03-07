#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------
FROM python:3.7-stretch

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install git, process tools, lsb-release (common in install instructions for CLIs)
RUN apt-get -y install git procps lsb-release 

# Install any missing dependencies for enhanced language service, along with password generator
RUN apt-get install -y libicu[0-9][0-9] && apt-get install -y makepasswd

# Install Azure CLI and application insights and azure devops extension
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN az extension add --name application-insights
RUN az extension add --name azure-devops

# Install Databricks CLI
RUN pip install databricks-cli

# Install jq & makepasswd for some frequently used utility
RUN apt-get update \
    && apt-get -y install jq makepasswd

# Install mssql-cli
# 1/2) adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# 2/2) install SQL Server drivers and tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-cli msodbcsql mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# sqlpackage
# docker  sqlpackage: https://github.com/markhobson/docker-sqlpackage/blob/master/Dockerfile
# install sqlpackage: https://docs.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver15
ARG SQLPACKAGE_URL=https://download.microsoft.com/download/0/2/0/020aa2fa-f3f2-41ba-bacd-ff15557890d3/sqlpackage-linux-x64-en-US-15.0.5084.2.zip
RUN apt update \
	&& apt install -y wget zip libunwind8 \
	&& wget -O sqlpackage-linux.zip $SQLPACKAGE_URL \
	&& mkdir /opt/sqlpackage \
	&& unzip sqlpackage-linux.zip -d /opt/sqlpackage \
	&& chmod a+x /opt/sqlpackage/sqlpackage \
	&& ln -s /opt/sqlpackage/sqlpackage /usr/bin/sqlpackage

# Install java
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

RUN mkdir /workspace
WORKDIR /workspace



# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Set PACKAGE_VERSION to localdev
ENV PACKAGE_VERSION=localdev

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash
