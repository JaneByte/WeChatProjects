package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.dto.SubmitCommentRequest;
import com.example.freshtime.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/comment")
@CrossOrigin(origins = "*")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @PostMapping("/submit")
    public ApiResponse<?> submit(@RequestBody SubmitCommentRequest request) {
        request.setUserId(resolveUserId(request == null ? null : request.getUserId()));
        return commentService.submitComment(request);
    }

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam Long goodsId,
                               @RequestParam(defaultValue = "1") Integer page,
                               @RequestParam(defaultValue = "10") Integer pageSize) {
        return commentService.listByGoodsId(goodsId, page, pageSize);
    }

    @GetMapping("/summary")
    public ApiResponse<?> summary(@RequestParam Long goodsId) {
        return commentService.summaryByGoodsId(goodsId);
    }

    @GetMapping("/detail")
    public ApiResponse<?> detail(@RequestParam Long commentId,
                                 @RequestParam(required = false) Long userId) {
        return commentService.detailById(resolveUserId(userId), commentId);
    }

    private Long resolveUserId(Long userId) {
        Long authUserId = AuthContext.getUserId();
        return authUserId != null ? authUserId : userId;
    }
}
