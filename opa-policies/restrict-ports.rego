package k8sports

contains violation[{"msg": "Containers must only expose ports above 1024."}] if {
    container := input.review.object.spec.containers[_]
    port := container.ports[_].containerPort
    port < 1024
}