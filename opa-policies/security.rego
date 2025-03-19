package security

# Default deny unless all conditions pass
default allow = false

# Allow only if all checks pass
allow {
    no_root_container
    ports_above_1024
    volumes_read_only
}

# Check 1: No container runs as root
no_root_container {
    # Iterate over all containers in the spec
    containers := input.spec.template.spec.containers
    all([container.securityContext.runAsNonRoot == true | container := containers[_]])
}

# Check 2: Ports must be above 1024
ports_above_1024 {
    containers := input.spec.template.spec.containers
    all([port > 1024 | container := containers[_]; port := container.ports[_].containerPort])
}

# Check 3: Mounted volumes must be read-only
volumes_read_only {
    containers := input.spec.template.spec.containers
    all([volume.readOnly == true | container := containers[_]; volume := container.volumeMounts[_]])
}

# Violation messages for debugging
violations[msg] {
    not no_root_container
    msg := "Container is running as root"
}

violations[msg] {
    containers := input.spec.template.spec.containers
    some container, port
    containers[container].ports[port].containerPort <= 1024
    msg := sprintf("Container %v uses privileged port %v (must be > 1024)", [containers[container].name, containers[container].ports[port].containerPort])
}

violations[msg] {
    containers := input.spec.template.spec.containers
    some container, volume
    containers[container].volumeMounts[volume].readOnly != true
    msg := sprintf("Volume mount %v in container %v is not read-only", [containers[container].volumeMounts[volume].name, containers[container].name])
}