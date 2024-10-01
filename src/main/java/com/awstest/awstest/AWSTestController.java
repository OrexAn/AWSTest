package com.awstest.awstest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AWSTestController {
    @GetMapping
    public String getMain(){
        return "Hello World!";
    }
}
