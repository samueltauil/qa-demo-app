// ============================================================
// XSS fix for the profile page
// Compare with src/views/profile.ejs to see the vulnerability.
//
// The fix: change <%- user.bio %> to <%= user.bio %>
// This escapes HTML entities, preventing script injection.
// ============================================================

// BEFORE (vulnerable):
//   <div class="bio"><%- user.bio %></div>
//
// AFTER (fixed):
//   <div class="bio"><%= user.bio %></div>

// The profile.ejs template should use EJS escaped output (<%= %>)
// instead of unescaped output (<%- %>) for user-supplied content.
