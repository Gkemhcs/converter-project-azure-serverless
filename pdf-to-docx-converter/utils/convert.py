from pdf2docx import Converter

def pdf_to_docx(pdf_file, docx_file):
    # Create a Converter object
    cv = Converter(pdf_file)
    # Convert the PDF to DOCX
    cv.convert(docx_file, start=0, end=None)
    # Close the converter
    cv.close()