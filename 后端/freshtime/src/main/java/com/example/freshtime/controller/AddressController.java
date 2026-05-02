package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveAddressRequest;
import com.example.freshtime.service.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/address")
@CrossOrigin(origins = "*")
public class AddressController {

    @Autowired
    private AddressService addressService;

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam Long userId) {
        return addressService.list(userId);
    }

    @PostMapping("/save")
    public ApiResponse<?> save(@RequestBody SaveAddressRequest request) {
        return addressService.save(request);
    }

    @DeleteMapping("/delete")
    public ApiResponse<?> delete(@RequestParam Long userId, @RequestParam Long id) {
        return addressService.remove(userId, id);
    }
}
