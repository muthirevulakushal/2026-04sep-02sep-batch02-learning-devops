package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String hello() {
		return "Greetings from Spring Boot V2.0!";
	}

	@GetMapping("/myapp1")
	public String myapp1() {
		return "Greetings from myapp1!";
	}

	@GetMapping("/myapp2")
	public String myapp2() {
		return "Greetings from myapp2!";
	}

}
