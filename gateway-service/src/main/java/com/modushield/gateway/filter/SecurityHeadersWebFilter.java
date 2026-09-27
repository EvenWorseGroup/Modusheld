package com.modushield.gateway.filter;

import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

/** Adds security headers to every response produced by the gateway application. */
@Component
public class SecurityHeadersWebFilter implements WebFilter, Ordered {

    static final String X_CONTENT_TYPE_OPTIONS = "X-Content-Type-Options";
    static final String NOSNIFF = "nosniff";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        exchange.getResponse().beforeCommit(() -> {
            HttpHeaders headers = exchange.getResponse().getHeaders();
            headers.set(X_CONTENT_TYPE_OPTIONS, NOSNIFF);
            return Mono.empty();
        });
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
