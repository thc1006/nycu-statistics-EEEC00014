FROM rocker/verse:4.4.1

# 統計作業需要的 R 套件
RUN R -e "install.packages(c('pacman','car','BSDA','tolerance','ggpubr'), \
    repos='https://cloud.r-project.org', Ncpus = 4)"

# 一次裝好所有 PDF 排版會用到的東西，避免來回 rebuild
#  - fonts-noto-cjk*：中文字型
#  - texlive-xetex：xelatex 引擎
#  - texlive-fonts-recommended/extra：基本與額外字型
#  - texlive-lang-chinese / texlive-lang-cjk：xeCJK、ctex 等中文巨集
#  - texlive-latex-recommended：lmodern 之外的主要排版套件
#  - texlive-latex-extra：fvextra、tcolorbox、fancyhdr、titling、caption…
#  - texlive-pictures：tcolorbox 'most' 選項依賴 TikZ
#  - texlive-science：amsmath 進階、mhchem 等
#  - texlive-plain-generic：一些通用 plain TeX 巨集
#  - lmodern：lmodern.sty (rmarkdown 預設要)
#  - latexmk：方便完整解析參考、目錄
RUN apt-get update && apt-get install -y --no-install-recommends \
        fonts-noto-cjk fonts-noto-cjk-extra \
        texlive-xetex \
        texlive-fonts-recommended texlive-fonts-extra \
        texlive-lang-chinese texlive-lang-cjk \
        texlive-latex-recommended texlive-latex-extra \
        texlive-pictures texlive-science texlive-plain-generic \
        lmodern latexmk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
