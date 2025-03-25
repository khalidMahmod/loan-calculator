# config/initializers/mime_types.rb

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# Register PDF MIME type if it's not already registered
Mime::Type.register "application/pdf", :pdf unless Mime::Type.lookup_by_extension(:pdf)
