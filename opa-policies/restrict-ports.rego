package k8sports

violation[{"msg": "Container is missing ports configuration."}] {
    container := input.review.object.spec.containers[_]
    not container.ports
}

violation[{"msg": "Containers must only expose ports above 1024."}] {
    container := input.review.object.spec.containers[_]
    port := container.ports[_].containerPort
    port < 1024
}