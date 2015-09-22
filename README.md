# vennGen
Simple bison-based translator that converts statements of set theory into Venn diagrams

At the moment, this utility only reads text from the command line, and produces output the the command line. The
 following command will translate a file, EXAMPLE, into an output file, EXAMPLE-OUTPUT.tex:
 
 cat EXAMPLE | ./venn > EXAMPLE-OUTPUT.tex
