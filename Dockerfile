FROM registry.access.redhat.com/ubi8/openjdk-17:1.17
 
WORKDIR /app
 
# Create the package directory structure
RUN mkdir -p com/example/chatapp
 
# Create a proper HTTP server
RUN echo 'package com.example.chatapp;' > com/example/chatapp/SimpleServer.java && \
    echo 'import java.io.*;' >> com/example/chatapp/SimpleServer.java && \
    echo 'import java.net.*;' >> com/example/chatapp/SimpleServer.java && \
    echo 'public class SimpleServer {' >> com/example/chatapp/SimpleServer.java && \
    echo '  public static void main(String[] args) throws Exception {' >> com/example/chatapp/SimpleServer.java && \
    echo '    ServerSocket ss = new ServerSocket(8080);' >> com/example/chatapp/SimpleServer.java && \
    echo '    System.out.println("Server running on port 8080");' >> com/example/chatapp/SimpleServer.java && \
    echo '    while(true) {' >> com/example/chatapp/SimpleServer.java && \
    echo '      try (Socket s = ss.accept(); BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream())); PrintWriter out = new PrintWriter(s.getOutputStream(), true)) {' >> com/example/chatapp/SimpleServer.java && \
    echo '        String line; while((line = in.readLine()) != null && !line.isEmpty()) {}' >> com/example/chatapp/SimpleServer.java && \
    echo '        out.println("HTTP/1.1 200 OK");' >> com/example/chatapp/SimpleServer.java && \
    echo '        out.println("Content-Type: text/html");' >> com/example/chatapp/SimpleServer.java && \
    echo '        out.println();' >> com/example/chatapp/SimpleServer.java && \
    echo '        out.println("<h1>Hello from ChatApp!</h1>");' >> com/example/chatapp/SimpleServer.java && \
    echo '      } catch(Exception e) { e.printStackTrace(); }' >> com/example/chatapp/SimpleServer.java && \
    echo '    }' >> com/example/chatapp/SimpleServer.java && \
    echo '  }' >> com/example/chatapp/SimpleServer.java && \
    echo '}' >> com/example/chatapp/SimpleServer.java
 
# Compile and create JAR
RUN javac com/example/chatapp/SimpleServer.java && \
    jar cfe app.jar com.example.chatapp.SimpleServer com/example/chatapp/*.class
 
EXPOSE 8080
 
ENTRYPOINT ["java", "-jar", "app.jar"]
