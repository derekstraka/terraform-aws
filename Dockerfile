
ARG TERRAFORM_VERSION
ARG AWS_CLI_VERSION

FROM  hashicorp/terraform:${TERRAFORM_VERSION} as aws-cli
ARG AWS_CLI_VERSION
ARG PYTHON_VERSION
# Install development packages to build wheels needed by the AWS CLI (e.g. cffi, psutil)
ENV PYTHONUNBUFFERED=1
# Don't pin the packages to allow floating versions based on build arguments
# hadolint ignore=DL3018
RUN apk add --update --no-cache gcc musl-dev linux-headers libffi-dev python3 python3-dev && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
# Don't pin the packages to allow floating versions based on build arguments
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip setuptools && \
    pip3 install --no-cache-dir awscli==${AWS_CLI_VERSION}

# Build final image with the aws command line tools
FROM  hashicorp/terraform:${TERRAFORM_VERSION}
LABEL org.opencontainers.image.authors="derek@asterius.io"
ENV HISTFILE=/data/.bash_history
# Don't pin the packages to allow floating versions based on build arguments
# hadolint ignore=DL3013,DL3018
RUN apk add --update --no-cache python3 bash \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \ 
    && pip3 install --no-cache-dir --upgrade pip setuptools
RUN ln -sf /usr/lib/python3* /usr/lib/python3
COPY --from=aws-cli /usr/bin/aws* /usr/bin/
COPY --from=aws-cli /usr/lib/python3.*/site-packages /usr/lib/python3/site-packages

ENTRYPOINT ["/bin/bash", "-c"]