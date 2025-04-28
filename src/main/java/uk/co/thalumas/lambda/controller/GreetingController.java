package uk.co.thalumas.lambda.controller;

import lombok.extern.slf4j.Slf4j;
import uk.co.thalumas.lambda.model.GreetingRequest;
import uk.co.thalumas.lambda.model.GreetingResponse;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@RestController
@EnableWebMvc
@Slf4j
public class GreetingController {
    @PostMapping(path = "/greet", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public GreetingResponse greet(@RequestBody GreetingRequest greetingRequest) {
        log.info("Greeting request: {}", greetingRequest);
        return GreetingResponse.builder().greeting("Greetings " + greetingRequest.getName()).build();
    }
}
