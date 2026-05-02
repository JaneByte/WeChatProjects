package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveAddressRequest;

public interface AddressService {
    ApiResponse<?> list(Long userId);

    ApiResponse<?> save(SaveAddressRequest request);

    ApiResponse<?> remove(Long userId, Long id);
}
