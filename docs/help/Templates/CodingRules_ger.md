## 1. Allgemeine Regeln
- **Lesbarkeit vor Komplexität:** Schreibe Code so, dass er leicht zu verstehen und zu warten ist.
- **DRY-Prinzip:** Vermeide Code-Duplikate („Don’t Repeat Yourself“).
- **Version Control:** Jeder Merge in Main (Wunsch bei jedem Commit) muss funktionierende, getestete und dokumentierte Änderungen enthalten.
---
## 2. Namenskonventionen
- **Dateinamen:** Verwende `snake_case` für beide Sprachen.  
    Beispiel: `my_module.cpp`, `my_class.h`, `my_script.py`.
- **Klassen:** Verwende `PascalCase` für beide Sprachen.  
    Beispiel: `MyClass`.
- **Funktionen und Methoden:** Verwende `snake_case` für beide Sprachen.  
    Beispiel: `do_something()`.
- **Variablen:** Verwende `snake_case` für beide Sprachen.  
    Beispiel: `my_variable`.
- **Konstanten:** Verwende `UPPER_SNAKE_CASE` für beide Sprachen.  
    Beispiel: `MAX_COUNT`.
- **Namespaces (C++) und Module (Python):** Verwende `snake_case`.  
    Beispiel: `namespace my_namespace` (C++), `import my_module` (Python).
---
### Python: Naming und Dokumentation von Klassen
- **Klassen-Namen:** Verwende `PascalCase`.  
    Beispiel: `MyClass`
- **Klassen-Docstring:** Jede Klasse erhält einen kurzen beschreibenden Docstring direkt nach der Definition, der die Funktion und ggf. wichtige Attribute erläutert.  
    Beispiel:
    ```python
    class MyClass:
        """
        Short description of what this class represents or does.
    
        Attributes:
            attribute1 (int): Description of attribute1.
            attribute2 (str): Description of attribute2.
        """
        def __init__(self, attribute1: int, attribute2: str):
            self.attribute1 = attribute1
            self.attribute2 = attribute2
    ```
- **Private/protected Attribute:**
    - **protected:** `_attribute`
    - **private:** `__attribute`  
        (Hinweis: Echter Zugriffsschutz wie in C++ existiert in Python nicht.)
---
## 3. Aufbau von Dateien
### C++
1. **Header-Dateien (.h):**
    - Enthalten Deklarationen von Klassen, Funktionen und Konstanten.
    - Verwende Include-Guards oder `#pragma once`.
    - Beispiel:
        
        ```cpp
        #ifndef MY_CLASS_H
        #define MY_CLASS_H
        
        class MyClass {
        public:
            void do_something();
        private:
            int my_variable;
        };
        
        #endif
        ```
2. **Implementierungsdateien (.cpp):**
    - Enthalten die Definitionen aus den Header-Dateien.
    - Halte Funktionen und Methoden möglichst kurz und modular.
### Python
- Importiere zuerst Standardbibliotheken, dann Drittanbieter-Bibliotheken, dann interne Module.
- Beispiel:
    ```python
    import os
    import sys
    
    import numpy as np

    from my_module import my_function
    ```
---
## 4. Comments and Documentation
### Required
- **Doxygen Style:** Verwende Doxygen-kompatible Kommentare für beide Sprachen.
- **Function Comments:**
    - **C++ Beispiel:**
        ```cpp
        /**
         * Calculates the sum of two numbers.
         * @param a The first number.
         * @param b The second number.
         * @return The sum of a and b.
         */
        int add(int a, int b);
        ```
    - **Python Beispiel:**
        ```python
        def add(a: int, b: int) -> int:
            """
            Calculates the sum of two numbers.
        
            Args:
                a (int): The first number.
                b (int): The second number.
        
            Returns:
                int: The sum of a and b.
            """
            return a + b
        ```
- **Inline Comments:** Möglichst sparsam und immer kurz und präzise.
    - Beispiel:
        ```cpp
        int count = 0; // Counter for the loop
        ```
---
### Additional
- **@note:**
    - Verwende `@note`, um wichtige Hinweise, Annahmen oder Einschränkungen zu erklären, die nicht sofort ersichtlich sind.
    - Beispiele für @note:
        - Annahmen zu Parameterbereichen oder Typen.
        - Einfluss bestimmter Konfigurationen auf die Performance.
        - Bekannte Einschränkungen oder Kompatibilitätsprobleme.
- **#TODO:**
    - Verwende `#TODO`, um mögliche Verbesserungen, Bugs oder Workarounds. Direkt beschreiben!
    - Beispiele für `#TODO`:
        - Einfluss bestimmter Konfigurationen auf die Performance. -> "#TODO: Make Possible for all Datasets, only works for Dataset A at the Moment"
        - Bekannte Einschränkungen oder Kompatibilitätsprobleme.-> "#TODO: Only Works with Python 2.11"
---
## 5. Code-Stil
- **Einrückung:** Verwende 4 Leerzeichen (keine Tabs!).
- **Zeilenlänge:** Maximal 80–100 Zeichen.
- **Leerzeilen:** Nutze Leerzeilen zur logischen Abgrenzung.
- **Blocks und Klammern:**
    - C++: Öffnende `{` in derselben Zeile wie die Anweisung.
        ```cpp
        if (condition) {
            do_something();
        }
        ```
    - Python: Nutze logische Einrückungen und halte PEP8 ein.
---
## 6. Best Practices
- **Fehlerbehandlung:** Nutze Ausnahmen (C++: `try-catch`, Python: `try-except`) statt Rückgabewerte für Fehler.
- **Unit-Tests:** Stelle sicher, dass für jede Funktionalität Unit-Tests vorhanden sind.
- **Code-Reviews:** Jeder Code muss vor dem Merge überprüft werden.
---
## 7. Zusätzliche Tools
- **Code Formatter:** Verwende Tools wie `clang-format` (C++) und `black` (Python) für automatisches Formatieren.
- **Linting:** Nutze `cpplint` (C++) und `pylint` (Python), um Code-Qualität sicherzustellen.
---

Git und Dokumentation

Opensource
