package com.casadeoxala.infrastructure.api.controller;

import com.casadeoxala.infrastructure.api.response.HealthCheckResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthCheckController {

    @GetMapping
    public ResponseEntity<HealthCheckResponse> getHealth() {
        return ResponseEntity.ok(new HealthCheckResponse("UP"));
    }
}