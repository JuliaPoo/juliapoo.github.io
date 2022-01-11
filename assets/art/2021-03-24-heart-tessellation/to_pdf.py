# https://github.com/Kozea/CairoSVG/issues/200

import cairocffi
from cairosvg.parser import Tree
from cairosvg.surface import PDFSurface

class RecordingPDFSurface(PDFSurface):
    surface_class = cairocffi.RecordingSurface

    def _create_surface(self, width, height):
        cairo_surface = cairocffi.RecordingSurface(cairocffi.CONTENT_COLOR_ALPHA, (0, 0, width, height))
        return cairo_surface, width, height  

def convert_list(urls, write_to, dpi=72):
    surface = cairocffi.PDFSurface(write_to, 1, 1)
    context = cairocffi.Context(surface)
    for url in urls:
        image_surface = RecordingPDFSurface(Tree(url=url), None, dpi)
        surface.set_size(image_surface.width, image_surface.height)
        context.set_source_surface(image_surface.cairo, 0, 0)
        context.paint()
        surface.show_page()
    surface.finish()

convert_list(['full_diagram_inkscape.svg'], 'final.pdf')