package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
@CrossOrigin(origins = "*")
public class UploadController {
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024;

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @Value("${app.public-base-url:}")
    private String publicBaseUrl;

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<?> uploadImage(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        if (file == null || file.isEmpty()) {
            return ApiResponse.badRequest("请先选择图片");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            return ApiResponse.badRequest("图片不能超过2MB");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ApiResponse.badRequest("仅支持图片文件");
        }

        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename() == null ? "" : file.getOriginalFilename());
        String extension = getExtension(originalFilename);
        if (extension.isEmpty()) {
            extension = ".jpg";
        }

        Path uploadRoot = Paths.get(uploadDir).toAbsolutePath().normalize();
        Path targetFile = uploadRoot.resolve(UUID.randomUUID().toString().replace("-", "") + extension).normalize();
        if (!targetFile.startsWith(uploadRoot)) {
            return ApiResponse.badRequest("上传文件路径不合法");
        }

        try {
            Files.createDirectories(uploadRoot);
            Files.copy(file.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ex) {
            return ApiResponse.serverError("图片上传失败，请稍后重试");
        }

        String fileName = targetFile.getFileName().toString();
        String baseUrl = resolveBaseUrl(request);
        Map<String, Object> data = new HashMap<>();
        data.put("url", baseUrl + "/uploads/" + fileName);
        data.put("fileName", fileName);
        return ApiResponse.success("上传成功", data);
    }

    private String resolveBaseUrl(HttpServletRequest request) {
        if (StringUtils.hasText(publicBaseUrl)) {
            return publicBaseUrl.replaceAll("/+$", "");
        }
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && serverPort == 80)
                || ("https".equalsIgnoreCase(scheme) && serverPort == 443);
        return defaultPort ? scheme + "://" + serverName : scheme + "://" + serverName + ":" + serverPort;
    }

    private String getExtension(String filename) {
        int index = filename.lastIndexOf('.');
        if (index < 0 || index == filename.length() - 1) {
            return "";
        }
        return filename.substring(index).toLowerCase();
    }
}
