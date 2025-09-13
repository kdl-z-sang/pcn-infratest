FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.17
 
WORKDIR /app
 
# Switch to root user temporarily to avoid permission issues
USER root
 
# Create a simple Java web server
RUN echo 'package com.example.chatapp;' > SimpleServer.java && \
    echo 'import java.io.*;' >> SimpleServer.java && \
    echo 'import java.net.*;' >> SimpleServer.java && \
    echo 'public class SimpleServer {' >> SimpleServer.java && \
    echo '  public static void main(String[] args) throws Exception {' >> SimpleServer.java && \
    echo '    ServerSocket ss = new ServerSocket(8080);' >> SimpleServer.java && \
    echo '    System.out.println("Server running on port 8080");' >> SimpleServer.java && \
    echo '    while(true) {' >> SimpleServer.java && \
    echo '      Socket s = ss.accept();' >> SimpleServer.java && \
    echo '      PrintWriter out = new PrintWriter(s.getOutputStream());' >> SimpleServer.java && \
    echo '      out.println("HTTP/1.1 200 OK\\r\\nContent-Type: text/html\\r\\n\\r\\n<h1>Hello from ChatApp!</h1>");' >> SimpleServer.java && \
    echo '      out.close(); s.close();' >> SimpleServer.java && \
    echo '    }' >> SimpleServer.java && \
    echo '  }' >> SimpleServer.java && \
    echo '}' >> SimpleServer.java
 
# Compile and create JAR
RUN javac SimpleServer.java && \
    jar cfe app.jar com.example.chatapp.SimpleServer *.class
 
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
