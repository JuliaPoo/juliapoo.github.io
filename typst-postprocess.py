import sys
from pathlib import Path
from bs4 import BeautifulSoup
import yaml
import re
import shutil
import os

JEKYLL_BUILD_PATH = Path("../_posts")
HTML_BUILD_PATH = Path("build")
JEKYLL_RESOURCE_PATH = Path("../assets/posts")
RESOURCE_PATH = Path("assets/posts")
PDF_BUILD_PATH = Path("build")

JEKYLL_TEMPLATE = lambda pdf_loc, frontmatter, html: f"""
---
{frontmatter}
---

To read this post as a (lightmode) pdf, [click here]({pdf_loc}).

{{% raw %}}

{html}

{{% endraw %}}
""".strip()
START_TOKEN = "// START METADATA //"
END_TOKEN = "// END METADATA //"
PATTERN_STR = lambda n: r"\n +" + n + r'\: "(.+)",\n'
PATTERN_ARR = lambda n: r"\n +" + n + r'\: (.+),\n'


if __name__ == "__main__":

    _, typst_fn = sys.argv
    typst_loc = Path(typst_fn)
    fn, path = typst_loc.stem, typst_loc.parent
    html_loc = path / HTML_BUILD_PATH / f"{fn}.html"
    pdf_loc = path / HTML_BUILD_PATH / f"{fn}.pdf"
    final_build_loc = path / JEKYLL_BUILD_PATH / f"{fn}.md"
    rsrc_loc = path / RESOURCE_PATH / fn
    debug_build_rsrc_loc = path / HTML_BUILD_PATH / RESOURCE_PATH / fn
    jekyll_build_rsrc_loc = path / JEKYLL_RESOURCE_PATH / fn

    typst_cnt = open(typst_loc).read()
    html_cnt = open(html_loc).read()

    metadata, = re.findall(f"{START_TOKEN}(.+){END_TOKEN}", typst_cnt, re.DOTALL)
    
    layout, = re.findall(PATTERN_STR("layout"), metadata)
    author, = re.findall(PATTERN_STR("author"), metadata)
    category, = re.findall(PATTERN_STR("category"), metadata)
    title, = re.findall(PATTERN_STR("display-title"), metadata)
    excerpt, = re.findall(PATTERN_STR("excerpt"), metadata)
    tags, = re.findall(PATTERN_ARR("tags"), metadata)
    tags = eval(tags) # dangerous but only I'm using this lmaooooo

    soup = BeautifulSoup(html_cnt, 'html.parser')
    html_body = soup.body

    metadata = {
        "layout": layout,
        "author": author,
        "category": category,
        "backend": "typst",
        "display-title": title,
        "tags": list(tags),  
        "excerpt": excerpt
    }
    front_matter = yaml.dump(metadata, default_flow_style=False, sort_keys=False)

    jekyll_final = JEKYLL_TEMPLATE(
        f"/assets/posts/{fn}/{fn}.pdf",
        front_matter,
        str(html_body)
    )

    open(final_build_loc, "w").write(jekyll_final)
    shutil.copytree(rsrc_loc, debug_build_rsrc_loc, dirs_exist_ok=True)
    shutil.copytree(rsrc_loc, jekyll_build_rsrc_loc, dirs_exist_ok=True)
    shutil.copy(pdf_loc, jekyll_build_rsrc_loc)
