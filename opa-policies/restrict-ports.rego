package k8sports

violation[{"msg": "Containers must only expose ports above 1024"}] {
    container := input.review.object.spec.containers[_]
    port := container.ports[_].containerPort
    if port < 1024 {
        msg := "Containers must only expose ports above 1024."
    }
}