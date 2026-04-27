package com.example.freshtime;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.freshtime.mapper")
public class FreshtimeApplication {

    public static void main(String[] args) {
        SpringApplication.run(FreshtimeApplication.class, args);
    }

}
