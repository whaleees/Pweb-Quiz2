package quiz2.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Get the current session (if exists)
        HttpSession session = httpRequest.getSession(false);

        // Check if user is logged in
        boolean isLoggedIn = (session != null && session.getAttribute("email") != null);

        // Get the requested URI
        String requestURI = httpRequest.getRequestURI();

        // Allow access to login and signup pages without authentication
        boolean isLoginOrSignup = requestURI.endsWith("login") || requestURI.endsWith("signup") 
                || requestURI.endsWith("login.jsp") || requestURI.endsWith("signup.jsp");

        if (isLoggedIn || isLoginOrSignup) {
            // User is logged in or accessing login/signup, continue the request
            chain.doFilter(request, response);
        } else {
            // Redirect to the login page
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
        }
    }
}
