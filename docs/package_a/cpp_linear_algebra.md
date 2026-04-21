# C++ Reference – Eigen (Linear Algebra)

> **Purpose:** Quick reference for the Eigen library used in this project.
> Add package-specific descriptions, API notes, and gotchas here so the AI
> assistant can read them as context when working on C++ code.

---

## Package Info

| Property | Value |
|---|---|
| Library | Eigen 3.x |
| Header | `#include <Eigen/Dense>` |
| Namespace | `Eigen::` |
| License | MPL2 |
| Docs | https://eigen.tuxfamily.org/dox/ |

---

## Core Types

```cpp
// Fixed-size matrix (rows x cols, stored column-major by default)
Eigen::Matrix<float, 3, 3> mat33;        // 3x3 float matrix
Eigen::Matrix<double, 4, 1> vec4d;       // 4-element double column vector

// Convenience typedefs
Eigen::MatrixXf   A;    // dynamic float matrix
Eigen::MatrixXd   B;    // dynamic double matrix
Eigen::VectorXf   v;    // dynamic float column vector
Eigen::Vector3f   p;    // fixed 3-element float vector
```

---

## Initialization

```cpp
Eigen::Matrix3f m;
m << 1, 2, 3,
     4, 5, 6,
     7, 8, 9;

Eigen::MatrixXd Z = Eigen::MatrixXd::Zero(4, 4);
Eigen::MatrixXd I = Eigen::MatrixXd::Identity(3, 3);
Eigen::VectorXd r = Eigen::VectorXd::Random(5);
```

---

## Common Operations

```cpp
// Matrix arithmetic
Eigen::MatrixXf C = A + B;
Eigen::MatrixXf D = A * B;          // matrix product
Eigen::MatrixXf E = A.array() * B.array();  // element-wise product

// Transpose / inverse
Eigen::MatrixXf At = A.transpose();
Eigen::MatrixXf Ai = A.inverse();   // only for small fixed-size matrices; prefer solvers

// Norm and dot product
float n = v.norm();
float d = v.dot(w);
Eigen::Vector3f cross = v.cross(w); // only for Vector3
```

---

## Linear Solvers

```cpp
// Preferred: use a decomposition instead of A.inverse() * b
Eigen::VectorXd x = A.colPivHouseholderQr().solve(b);   // general, robust
Eigen::VectorXd x = A.ldlt().solve(b);                  // symmetric positive definite
Eigen::VectorXd x = A.lu().solve(b);                    // square, full rank
```

---

## Interop with CUDA / Raw Pointers

```cpp
// Map an existing raw float buffer (e.g. from CUDA host memory) as an Eigen matrix
float* raw = ...;
Eigen::Map<Eigen::MatrixXf> mapped(raw, rows, cols);

// @note: Eigen is NOT CUDA-device compatible out of the box.
// Use cuBLAS or custom kernels for device-side math;
// use Eigen on the host side for setup / verification only.
```

---

## Gotchas

- **Auto keyword:** `auto c = a + b;` can capture an *expression template*, not a matrix.
  Always write `MatrixXf c = a + b;` to force evaluation.
- **Column-major default:** Eigen stores matrices column-major; OpenCV and most C arrays
  are row-major. Use `Eigen::Matrix<float, Dynamic, Dynamic, RowMajor>` when interfacing.
- **Fixed vs dynamic size:** prefer fixed-size types (`Matrix3f`) for small, known sizes —
  they are stack-allocated and significantly faster.

---

## Adding More References

Copy this file as a template for other packages:
```
docs/cpp_referenz/cpp_referenz_2.md   ← e.g. OpenCV
docs/cpp_referenz/cpp_referenz_3.md   ← e.g. PCL
```
