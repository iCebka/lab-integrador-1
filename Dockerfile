FROM kestra/kestra:v1.3.37

USER root

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        python3-venv \
        python3-pip \
        git \
    && /usr/bin/python3 -m venv /opt/dbt-venv \
    && /opt/dbt-venv/bin/pip install --no-cache-dir dbt-snowflake==1.12.1 \
    && /opt/dbt-venv/bin/dbt --version \
    && git --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/dbt-venv/bin:${PATH}"