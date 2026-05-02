package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveAddressRequest;
import com.example.freshtime.entity.AddressInfo;
import com.example.freshtime.mapper.AddressMapper;
import com.example.freshtime.service.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AddressServiceImpl implements AddressService {

    @Autowired
    private AddressMapper addressMapper;

    @Override
    public ApiResponse<?> list(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        List<AddressInfo> list = addressMapper.selectByUserId(userId);
        return ApiResponse.success(list);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> save(SaveAddressRequest request) {
        if (request == null || request.getUserId() == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        if (isEmpty(request.getReceiverName()) || isEmpty(request.getReceiverPhone()) || isEmpty(request.getDetail())) {
            return ApiResponse.badRequest("请填写完整地址信息");
        }

        AddressInfo address = new AddressInfo();
        address.setId(request.getId());
        address.setUserId(request.getUserId());
        address.setReceiverName(request.getReceiverName().trim());
        address.setReceiverPhone(request.getReceiverPhone().trim());
        address.setProvince(defaultText(request.getProvince()));
        address.setCity(defaultText(request.getCity()));
        address.setDistrict(defaultText(request.getDistrict()));
        address.setDetail(request.getDetail().trim());
        address.setIsDefault(request.getIsDefault() != null && request.getIsDefault() == 1 ? 1 : 0);

        if (address.getIsDefault() == 1) {
            addressMapper.clearDefaultByUserId(address.getUserId());
        }

        if (address.getId() == null) {
            addressMapper.insertAddress(address);
        } else {
            int updated = addressMapper.updateAddress(address);
            if (updated <= 0) {
                return ApiResponse.badRequest("地址不存在或无权限修改");
            }
        }

        return ApiResponse.success("保存成功", null);
    }

    @Override
    public ApiResponse<?> remove(Long userId, Long id) {
        if (userId == null || id == null) {
            return ApiResponse.badRequest("userId和id不能为空");
        }
        int deleted = addressMapper.deleteByIdAndUserId(id, userId);
        if (deleted <= 0) {
            return ApiResponse.badRequest("地址不存在或无权限删除");
        }
        return ApiResponse.success("删除成功", null);
    }

    private boolean isEmpty(String text) {
        return text == null || text.trim().isEmpty();
    }

    private String defaultText(String text) {
        return text == null ? "" : text.trim();
    }
}
