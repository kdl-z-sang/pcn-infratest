package com.example.chatapp;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
public class ChatController {
    
    private List<String> messages = new ArrayList<>();
    
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("messages", messages);
        return "chat";
    }
    
    @PostMapping("/send")
    public String sendMessage(@RequestParam String message) {
        if (message != null && !message.trim().isEmpty()) {
            messages.add(message.trim());
        }
        return "redirect:/";
    }
    
    @GetMapping("/health")
    @ResponseBody
    public String health() {
        return "OK";
    }
}
