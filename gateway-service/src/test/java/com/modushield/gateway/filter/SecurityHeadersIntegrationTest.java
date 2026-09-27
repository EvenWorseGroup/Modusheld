package com.modushield.gateway.filter;

import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpResponseStatus;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "modushield.access.api-key=integration-key",
                "modushield.auth.jwt-secret=integration-test-secret-at-least-32-bytes-long",
                "modushield.auth.admin-username=test-admin",
                "modushield.auth.admin-password=test-password-123"
        })
@AutoConfigureWebTestClient
class SecurityHeadersIntegrationTest {

    private static final DisposableServer UPSTREAM = HttpServer.create()
            .host("127.0.0.1")
            .port(0)
            .route(routes -> routes.post("/api/orders", (request, response) -> response
                    .status(HttpResponseStatus.CREATED)
                    .header(HttpHeaderNames.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .header(SecurityHeadersWebFilter.X_CONTENT_TYPE_OPTIONS, "unsafe-upstream-value")
                    .sendString(Mono.just("{\"orderId\":\"order-1\"}"))))
            .bindNow();

    @Autowired
    private WebTestClient webTestClient;

    @DynamicPropertySource
    static void configureUpstream(DynamicPropertyRegistry registry) {
        registry.add("spring.cloud.gateway.routes[0].id", () -> "security-headers-test");
        registry.add(
                "spring.cloud.gateway.routes[0].uri",
                () -> "http://127.0.0.1:" + UPSTREAM.port());
        registry.add(
                "spring.cloud.gateway.routes[0].predicates[0]",
                () -> "Path=/api/**");
    }

    @AfterAll
    static void stopUpstream() {
        UPSTREAM.disposeNow();
    }

    @Test
    void addsNosniffHeaderToHealthResponse() {
        webTestClient.get()
                .uri("/health")
                .exchange()
                .expectStatus().isOk()
                .expectHeader().valueEquals(
                        SecurityHeadersWebFilter.X_CONTENT_TYPE_OPTIONS,
                        SecurityHeadersWebFilter.NOSNIFF);
    }

    @Test
    void addsNosniffHeaderToProxiedResponse() {
        webTestClient.post()
                .uri("/api/orders")
                .header("X-API-Key", "integration-key")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue("{\"productId\":1,\"quantity\":1}")
                .exchange()
                .expectStatus().isCreated()
                .expectHeader().valueEquals(
                        SecurityHeadersWebFilter.X_CONTENT_TYPE_OPTIONS,
                        SecurityHeadersWebFilter.NOSNIFF)
                .expectBody()
                .jsonPath("$.orderId").isEqualTo("order-1");
    }
}
