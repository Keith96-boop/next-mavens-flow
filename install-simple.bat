@echo off
REM ============================================================================
REM Maven Flow Simple Installation Script (Windows CMD)
REM ============================================================================

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Parse arguments
set "INSTALL_MODE=%~1"
if "%INSTALL_MODE%"=="" set "INSTALL_MODE=global"

set "PROJECT_DIR=%~2"
if "%PROJECT_DIR%"=="" set "PROJECT_DIR=%CD%"

echo.
echo ================================================================
echo   Maven Flow Installation
echo ================================================================
echo.

REM Install globally
if "%INSTALL_MODE%"=="global" (
    echo Installing globally to %USERPROFILE%\.claude\

    REM Maven Flow internal files
    set "TARGET_DIR=%USERPROFILE%\.claude\maven-flow"
    REM Global locations for Claude Code
    set "AGENTS_DIR=%USERPROFILE%\.claude\agents"
    set "COMMANDS_DIR=%USERPROFILE%\.claude\commands"
    set "SKILLS_DIR=%USERPROFILE%\.claude\skills"

    REM Create directories
    if not exist "%TARGET_DIR%\hooks" mkdir "%TARGET_DIR%\hooks"
    if not exist "%TARGET_DIR%\config" mkdir "%TARGET_DIR%\config"
    if not exist "%TARGET_DIR%\.claude" mkdir "%TARGET_DIR%\.claude"
    if not exist "%AGENTS_DIR%" mkdir "%AGENTS_DIR%"
    if not exist "%COMMANDS_DIR%" mkdir "%COMMANDS_DIR%"
    if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"

    REM Copy agents to global location
    if exist "%SCRIPT_DIR%\.claude\agents" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\agents\*.md" "%AGENTS_DIR%\" >nul 2>&1
        echo [OK] Agents installed to ~/.claude/agents/
    )

    REM Copy commands to global location
    if exist "%SCRIPT_DIR%\.claude\commands" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\commands\*.md" "%COMMANDS_DIR%\" >nul 2>&1
        echo [OK] Commands installed to ~/.claude/commands/
    )

    REM Copy skills
    if exist "%SCRIPT_DIR%\.claude\skills" (
        for /D %%D in ("%SCRIPT_DIR%\.claude\skills\*") do (
            set "SKILL_NAME=%%~nxD"
            if not exist "!SKILLS_DIR!\!SKILL_NAME!" mkdir "!SKILLS_DIR!\!SKILL_NAME!"
            if exist "%%D\SKILL.md" (
                copy /Y "%%D\SKILL.md" "!SKILLS_DIR!\!SKILL_NAME!\" >nul 2>&1
            )
        )
        echo [OK] Skills installed
    )

    REM Copy hooks
    if exist "%SCRIPT_DIR%\.claude\maven-flow\hooks" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\maven-flow\hooks\*.sh" "%TARGET_DIR%\hooks\" >nul 2>&1
        echo [OK] Hooks installed
    )

    REM Copy config
    if exist "%SCRIPT_DIR%\.claude\maven-flow\config" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\maven-flow\config\*.mjs" "%TARGET_DIR%\config\" >nul 2>&1
        echo [OK] Config installed
    )

    REM Copy settings
    if exist "%SCRIPT_DIR%\.claude\maven-flow\.claude\settings.json" (
        copy /Y "%SCRIPT_DIR%\.claude\maven-flow\.claude\settings.json" "%TARGET_DIR%\.claude\" >nul 2>&1
        echo [OK] Settings configured
    )

    echo.
    echo [OK] Maven Flow installed globally!
    echo.
    echo Next steps:
    echo   1. Create a PRD: /flow-prd
    echo   2. Convert to JSON: /flow-convert
    echo   3. Start development: /flow start

    goto :end
)

REM Install locally
if "%INSTALL_MODE%"=="local" (
    echo Installing locally to %PROJECT_DIR%

    set "TARGET_DIR=%PROJECT_DIR%\.claude\maven-flow"
    set "SKILLS_DIR=%PROJECT_DIR%\.claude\skills"

    REM Create directories
    if not exist "%TARGET_DIR%\agents" mkdir "%TARGET_DIR%\agents"
    if not exist "%TARGET_DIR%\commands" mkdir "%TARGET_DIR%\commands"
    if not exist "%TARGET_DIR%\hooks" mkdir "%TARGET_DIR%\hooks"
    if not exist "%TARGET_DIR%\config" mkdir "%TARGET_DIR%\config"
    if not exist "%TARGET_DIR%\.claude" mkdir "%TARGET_DIR%\.claude"
    if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"
    if not exist "%PROJECT_DIR%\docs" mkdir "%PROJECT_DIR%\docs"

    REM Copy agents
    if exist "%SCRIPT_DIR%\.claude\agents" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\agents\*.md" "%TARGET_DIR%\agents\" >nul 2>&1
        echo [OK] Agents installed
    )

    REM Copy commands
    if exist "%SCRIPT_DIR%\.claude\commands" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\commands\*.md" "%TARGET_DIR%\commands\" >nul 2>&1
        echo [OK] Commands installed
    )

    REM Copy skills
    if exist "%SCRIPT_DIR%\.claude\skills" (
        for /D %%D in ("%SCRIPT_DIR%\.claude\skills\*") do (
            set "SKILL_NAME=%%~nxD"
            if not exist "!SKILLS_DIR!\!SKILL_NAME!" mkdir "!SKILLS_DIR!\!SKILL_NAME!"
            if exist "%%D\SKILL.md" (
                copy /Y "%%D\SKILL.md" "!SKILLS_DIR!\!SKILL_NAME!\" >nul 2>&1
            )
        )
        echo [OK] Skills installed
    )

    REM Copy hooks
    if exist "%SCRIPT_DIR%\.claude\maven-flow\hooks" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\maven-flow\hooks\*.sh" "%TARGET_DIR%\hooks\" >nul 2>&1
        echo [OK] Hooks installed
    )

    REM Copy config
    if exist "%SCRIPT_DIR%\.claude\maven-flow\config" (
        xcopy /Y /Q "%SCRIPT_DIR%\.claude\maven-flow\config\*.mjs" "%TARGET_DIR%\config\" >nul 2>&1
        echo [OK] Config installed
    )

    REM Copy settings
    if exist "%SCRIPT_DIR%\.claude\maven-flow\.claude\settings.json" (
        copy /Y "%SCRIPT_DIR%\.claude\maven-flow\.claude\settings.json" "%TARGET_DIR%\.claude\" >nul 2>&1
        echo [OK] Settings configured
    )

    REM Create prd.json if not exists
    if not exist "%PROJECT_DIR%\docs\prd.json" (
        echo {> "%PROJECT_DIR%\docs\prd.json"
        echo   "projectName": "My Project",>> "%PROJECT_DIR%\docs\prd.json"
        echo   "branchName": "main",>> "%PROJECT_DIR%\docs\prd.json"
        echo   "stories": []>> "%PROJECT_DIR%\docs\prd.json"
        echo }>> "%PROJECT_DIR%\docs\prd.json"
        echo [OK] Created docs/prd.json
    )

    REM Create progress.txt if not exists
    if not exist "%PROJECT_DIR%\docs\progress.txt" (
        echo # Maven Flow Progress> "%PROJECT_DIR%\docs\progress.txt"
        echo.>> "%PROJECT_DIR%\docs\progress.txt"
        echo ## Codebase Patterns>> "%PROJECT_DIR%\docs\progress.txt"
        echo ^<^!-- Add reusable patterns discovered during development --^>>> "%PROJECT_DIR%\docs\progress.txt"
        echo.>> "%PROJECT_DIR%\docs\progress.txt"
        echo ## Iteration Log>> "%PROJECT_DIR%\docs\progress.txt"
        echo ^<^!-- Progress from each iteration will be appended here --^>>> "%PROJECT_DIR%\docs\progress.txt"
        echo [OK] Created docs/progress.txt
    )

    echo.
    echo [OK] Maven Flow installed locally!
    echo.
    echo Next steps:
    echo   1. Create a PRD: /flow-prd
    echo   2. Convert to JSON: /flow-convert
    echo   3. Start development: /flow start

    goto :end
)

REM Invalid mode
echo [ERROR] Invalid install mode: %INSTALL_MODE%
echo.
echo Usage:
echo   install-simple.bat global     # Install globally
echo   install-simple.bat local      # Install locally
exit /b 1

:end
echo.
