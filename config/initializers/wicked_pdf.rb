# config/initializers/wicked_pdf.rb

WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using the wkhtmltopdf-binary gem
  # :exe_path => '/usr/local/bin/wkhtmltopdf',

  # Layout file to be used for all PDFs
  :layout => 'pdf.html',  # Changed from pdf.html.erb to pdf.html

  # Enable local file access
  :enable_local_file_access => true,

  # Additional rendering options
  :margin => {
    :top => 15,
    :bottom => 15,
    :left => 10,
    :right => 10
  }
}
