import numpy as np
import os
import urllib.request
import json

from aws_lambda_powertools import Logger, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger()
metrics = Metrics(service="MatrixComputation", namespace="DataRefinementProcess")
metrics.set_default_dimensions(environment="dev")

APPLICATION_NAME = os.environ["APPLICATION_NAME"]
ENVIRONMENT = os.environ["ENVIRONMENT"]
DEPLOYMENT = os.environ["DEPLOYMENT"]
CONFIG_NAME = os.environ["CONFIG_NAME"]
FEATURE_ACTIVATION_NAME = os.environ["FEATURE_ACTIVATION_NAME"]

@metrics.log_metrics
@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    """
    Based on https://gist.github.com/markus-beuckelmann/8bc25531b11158431a5b09a45abd6276
    """
    # Retrieve configuration
    url = f"http://localhost:2772/applications/{APPLICATION_NAME}/environments/{ENVIRONMENT}/configurations/{CONFIG_NAME}-{DEPLOYMENT}"
    config = urllib.request.urlopen(url).read()
    config_json = json.loads(config)
    logger.info(f"Application configuration: {config_json}")
    matrix_size = config_json.get("matrix_size")
    # Retrieve feature activation
    url = f"http://localhost:2772/applications/{APPLICATION_NAME}/environments/{ENVIRONMENT}/configurations/{FEATURE_ACTIVATION_NAME}?flag=matrix_decomposition"
    config = urllib.request.urlopen(url).read()
    config_json = json.loads(config)
    logger.info(f"Feature activation: {config_json}")
    matrix_decomposition_enabled = config_json.get("enabled")

    # Let's not take the randomness out of random numbers (for reproducibility)
    # np.random.seed(0)

    size = int(matrix_size)
    A, B = np.random.random((size, size)), np.random.random((size, size))
    C, D = np.random.random((size * 128,)), np.random.random((size * 128,))
    E = np.random.random((int(size / 2), int(size / 4)))
    F = np.random.random((int(size / 2), int(size / 2)))
    F = np.dot(F, F.T)
    G = np.random.random((int(size / 2), int(size / 2)))

    nb_computations = {
        "nb_mx_dot_computation": 0,
        "nb_vect_dot_computation": 0
    }

    # Matrix multiplication
    logger.info(f"Dotted two {size}x{size} matrices.")
    N = np.random.randint(100, 200)
    for i in range(N):
        np.dot(A, B)
    nb_computations["nb_mx_dot_computation"] = N
    del A, B

    # Vector multiplication
    logger.info(f"Dotted two vectors of length {size * 128}.")
    N = np.random.randint(100, 200)
    for i in range(N):
        np.dot(C, D)
    nb_computations["nb_vect_dot_computation"] = N
    del C, D

    if matrix_decomposition_enabled:
        nb_computations.update({
            "nb_mx_svd_computation": 0,
            "nb_mx_cholesky_computation": 0,
            "nb_mx_eig_computation": 0
        })

        # Singular Value Decomposition (SVD)
        logger.info("SVD of a {size}x{size} matrices.")
        N = np.random.randint(100, 200)
        for i in range(N):
            np.linalg.svd(E, full_matrices=False)
        nb_computations["nb_mx_svd_computation"] = N
        del E

        # Cholesky Decomposition
        logger.info("Cholesky decomposition of a {size}x{size} matrice.")
        N = np.random.randint(100, 200)
        for i in range(N):
            np.linalg.cholesky(F)
        nb_computations["nb_mx_cholesky_computation"] = N

        # Eigendecomposition
        logger.info("Eigendecomposition of a {size}x{size} matrice.")
        N = np.random.randint(100, 200)
        for i in range(N):
            np.linalg.eig(G)
        nb_computations["nb_mx_eig_computation"] = N

        # Log computations
        logger.info({"nb_computations": nb_computations})

    # Add number of computation as custom metrics
    for name, value in nb_computations.items():
        metrics.add_metric(name=name, unit="Count", value=value)
    nb_mx_total_computation = sum(nb_computations.values())
    metrics.add_metric(name="nb_mx_total_computation", unit=MetricUnit.Count, value=nb_mx_total_computation)
    response = {
        "statusCode": 200,
        "body": json.dumps({
            "matrix_size": matrix_size
        })
    }
    return response