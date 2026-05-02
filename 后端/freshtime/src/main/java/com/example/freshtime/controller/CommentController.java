package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitCommentRequest;
import com.example.freshtime.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/comment")
@CrossOrigin(origins = "*")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @PostMapping("/submit")
    public ApiResponse<?> submit(@RequestBody SubmitCommentRequest request) {
        return commentService.submitComment(request);
    }
}

