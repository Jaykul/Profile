@{
    FileColors = @{
        # Be careful not to use "white" or "black" since those are my normal background colors for work and presentation/admin
        # Directories can just stay the default foreground color
        "directory"  = FileFormat "[39m" 

        # Archive files are some shade of green
        ".7z"     = FileFormat "[38;2;179;230;204m" 
        ".bz"     = FileFormat "[38;2;179;230;204m" 
        ".tar"    = FileFormat "[38;2;179;230;204m" 
        ".zip"    = FileFormat "[38;2;179;230;204m" 

        # Executable things are shades of red
        ".bat"    = FileFormat "[38;2;255;99;71m" 
        ".cmd"    = FileFormat "[38;2;255;99;71m" 
        ".exe"    = FileFormat "[38;2;220;20;60m" ﬓ
        ".js"     = FileFormat "[38;2;255;99;71m" 
        ".pl"     = FileFormat "[38;2;255;99;71m" 
        ".ps1"    = FileFormat "[38;2;255;99;71m" ﲵ
        ".rb"     = FileFormat "[38;2;255;99;71m" 
        ".sh"     = FileFormat "[38;2;255;99;71m" 

        # Not-executable code files are shades of yellow
        ".dll"    = FileFormat "[38;2;255;215;0m" ﰤ
        ".pdb"    = FileFormat "[38;2;255;204;0m" ﰤ
        ".psm1"   = FileFormat "[38;2;255;215;0m" ﰤ

        # Importable Data files are shades of blue
        ".clixml" = FileFormat "[38;2;30;144;255m" 謹
        ".csv"    = FileFormat "[38;2;30;144;255m" 
        ".json"   = FileFormat "[38;2;30;144;255m" 
        ".ps1xml" = FileFormat "[38;2;30;144;255m" 謹
        ".psd1"   = FileFormat "[38;2;30;144;255m" 
        ".yml"    = FileFormat "[38;2;30;144;255m" 
        ".xml"    = FileFormat "[38;2;30;144;255m" 謹

        # Config files
        ".conf"   = FileFormat "[38;2;64;224;208m" 煉
        ".config" = FileFormat "[38;2;64;224;208m" 煉
        ".reg"    = FileFormat "[38;2;64;224;208m" 煉
        ".vscode" = FileFormat "[38;2;64;224;208m" 

        # Source Files
        ".cs"     = FileFormat "[38;2;255;215;0m" 
        ".fs"     = FileFormat "[38;2;255;215;0m" 

        # Source Control
        ".git"          = FileFormat "[38;2;255;69;0m" 
        ".gitignore"    = FileFormat "[38;2;255;69;0m" 
        ".gitattribute" = FileFormat "[38;2;255;69;0m" 

        # Project files
        ".csproj" = FileFormat "[38;2;199;21;133m" 
        ".sln"    = FileFormat "[38;2;199;21;133m" 
        ".user"   = FileFormat "[38;2;64;224;208m" 
        ".code-workspace" = FileFormat "[38;2;0;204;0m" 

        # Text data file #00BFFF
        ".log"    = FileFormat "[38;2;0;191;255m" 
        ".txt"    = FileFormat "[38;2;0;191;255m" 

        # Documents
        ".chm"    = FileFormat "[38;2;127;255;212m" 
        ".doc"    = FileFormat "[38;2;127;255;212m" 
        ".docx"   = FileFormat "[38;2;127;255;212m" 
        ".htm"    = FileFormat "[38;2;127;255;212m" 
        ".html"   = FileFormat "[38;2;127;255;212m" 
        ".pdf"    = FileFormat "[38;2;127;255;212m" 
        ".md"     = FileFormat "[38;2;127;255;212m" 
        ".xls"    = FileFormat "[38;2;127;255;212m" 
        ".xlsx"   = FileFormat "[38;2;127;255;212m" 

    }
}
