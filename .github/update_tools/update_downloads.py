import os
import re

from requests_html import HTMLSession


def get_cmder_download_url():
    """
    Return the latest download url for cmder full.

    Returns
    -------
    str
        Latest download url for for cmder full
    """
    session = HTMLSession()
    cmder_page = session.get("https://github.com/cmderdev/cmder/releases/latest")
    cmder_page.html.render()
    cmder_links = cmder_page.html.find("a.d-flex.flex-items-center.min-width-0")
    for cmder_link in cmder_links:
        cmder_link = cmder_link.attrs["href"]
        if cmder_link.endswith("cmder.zip"):
            return f"https://github.com/{cmder_link}"


def get_make_download_url():
    """
    Return the latest download url for make-without-guile.

    Returns
    -------
    str
        Latest download url for make-without-guile
    """
    make_download_url_pattern = re.compile(
        r"make-\d+(\.\d+)*-without-guile-w32-bin\.zip/download"
    )
    session = HTMLSession()
    download_page = session.get("https://sourceforge.net/projects/ezwinports/files/")
    download_page.html.render()
    links = download_page.html.find("#files_list tr a")
    for link in links:
        link = link.attrs["href"]
        if re.search(make_download_url_pattern, link):
            return link


def update_download_urls():
    """
    Updates the download urls for cmder and make in 'function_definitions.ps1'.
    """
    url_changed = False
    cmder_url_pattern = re.compile(
        r'^\$download_cmder_url = "(?P<cmderr_download_url>.+?)"$', re.MULTILINE
    )
    make_url_pattern = re.compile(
        r'^\$download_make_url = "(?P<make_download_url>.+?)"$', re.MULTILINE
    )
    cmderr_download_url = get_cmder_download_url()
    make_download_url = get_make_download_url()
    func_def_file_path = os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "powershell_files",
            "function_definitions.ps1",
        )
    )
    with open(func_def_file_path) as func_def_file:
        func_def = func_def_file.read()
    used_cmderr_download_url = re.search(cmder_url_pattern, func_def).group(
        "cmderr_download_url"
    )
    used_make_download_url = re.search(make_url_pattern, func_def).group(
        "make_download_url"
    )
    if cmderr_download_url != used_cmderr_download_url:
        print(f"Replacing cmderr_download_url with: {cmderr_download_url}")
        url_changed = True
        func_def = re.sub(
            cmder_url_pattern,
            f'$download_cmder_url = "{cmderr_download_url}"',
            func_def,
        )
    if make_download_url != used_make_download_url:
        print(f"Replacing make_download_url with: {make_download_url}")
        url_changed = True
        func_def = re.sub(
            make_url_pattern, f'$download_make_url = "{make_download_url}"', func_def
        )
    if url_changed:
        print(f"Writing changes to {func_def_file_path}")
        with open(func_def_file_path, "w") as func_def_file:
            func_def_file.write(func_def)


if __name__ == "__main__":
    update_download_urls()
