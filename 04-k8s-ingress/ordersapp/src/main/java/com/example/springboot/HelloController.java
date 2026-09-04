package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String hello() {
		return "Greetings from Orders with Spring Boot!";
	}

	@GetMapping("/orders")
	public String orders() {
		return "Greetings from Orders!";
	}
}
