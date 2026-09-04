package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String hello() {
		return "Greetings from Payments with Spring Boot!";
	}
	
	@GetMapping("/payments")
	public String payments() {
		return "Greetings from Payments!";
	}

}
