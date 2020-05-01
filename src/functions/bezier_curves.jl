export Casteljau, getBezierJunctionPoints, getBezierInnerPoints
export getBezierPoints, getBezierTangentVectors
@doc doc"""
    de_casteljau(M::Manifold, b::Array{P,1}) -> Function

return the Bézier curve $\beta(\cdot;p_0,\ldots,b_n)\colon [0,1] \to \mathcal M$ defined
by the control points $b_0,\ldots,b_n\in\mathcal M$, $n\in \mathbb N$, implemented using
the De Casteljau's algorithm[^Casteljau1953][^Casteljau1963] gneralized to
manifolds[^PopielNoakes2007]: Let $\gamma_{a,b}(t)$ denote the
shortest geodesic connecting $a,b\in\mathcal M$. Then the curve is defined by the recursion

````math
\begin{aligned}
    \beta(t;b_0,b_1) &= \gamma_{b_0,b_1}(t)\\
    \beta(t;b_0,\ldots,b_n) &= \gamma_{\beta(t;b_0,\ldots,b_{n-1}), \beta(t;b_1,\ldots,b_n)}(t),
````
and `P` is the type of a point on the `Manifold` `M`.

    de_casteljau(M::Manifold, B::Array{Array{P,1},1}) -> Function

Given a vector of control points
$B=\bigl( (b_{0,0},\ldots,b_{n_0,0}),\ldots,(b_{0,m},\ldots b_{n_m,m}) \bigr)$,
where the different segments might be of different degree(s) $n_0,\ldots,n_m$. The resulting
composite Bézier curve $c_B\colon[0,m] \to \mathcal M$ consists of $m$ segments which are
Bézier curves.

````math
c_B(t) \coloneqq
    \begin{cases}
        \beta(t; b_{0,0},\ldots,b_{n_0,0}) & \mbox{ if } t \in [0,1]\\
        \beta(t-i; b_{0,i},\ldots,b_{n_i,i}) & \mbox{ if }
            t\in (i,i+1], \quad i\in\{1,\ldots,m-1\}.
    \end{cases}
````

    de_casteljau(M::Manifold, b::Array{P,1}, t::Real)
    de_casteljau(M::Manifold, B::Arrray{Array{P,1},1}, t::Real)
    de_casteljau(M::Manifold, b::Array{P,1}, T::AbstractVector) -> AbstractVector
    de_casteljau(M::Manifold, B::Arrray{Array{P,1},1}, T::AbstractVector) -> AbstractVector

Return the point at time `t` or points at times `t` in `T` along the Bézier curve.


[^Casteljau1959]:
    > de Casteljau, P.: Outillage methodes calcul, Enveloppe Soleau 40.040 (1959),
    > Institute National de la Propriété Industrielle, Paris.
[^Casteljau1963]:
    > de Casteljau, P.: Courbes et surfaces à pôles, Microfiche P 4147-1,
    > André Citroën Automobile SA, Paris, (1963).
[^PopielNoakes2007]:
    > Popiel, T. and Noakes, L.: Bézier curves and $C^2$ interpolation in Riemannian
    > manifolds. Journal of Approximation Theory (2007), 148(2), pp. 111–127.-
    > doi: [10.1016/j.jat.2007.03.002](https://doi.org/10.1016/j.jat.2007.03.002).
"""
function de_casteljau(M::Manifold, b::Array{P,1}, t::Float64) where {P}
  if length(b) == 2 # just a geodesic -> recursion end
    return t -> shortest_geodesic(M,b[1],b[2],t)
  else
    return t-> shortest_geodesic(
        M,
        de_casteljau(M,b[1:end-1])(t),
        de_casteljau(M,b[2:end])(t),
        t,
    )
  end
end
function de_casteljau(M::Manifold, B::Array{Array{P,1},1}) where {P}
    return function (t)
        ((0<t) || (t> length(B))) && DomainError(
            "Parameter $(t) outside of domain of the composite Bézier curve [0,$(length(B))]."
        )
        de_casteljau(M,B[max(ceil(Int,t),1)])( ceil(Int,t) == 0 ? 0. : t-ceil(Int,t)+1)
    end
end
de_casteljau(M::Manifold, b, t::Real) = de_casteljau(M,b)(t)
de_casteljau(M::Manifold, b, T::AbstractVector) = map(t -> de_casteljau(M,b,t), T)

@doc doc"""
    get_Bezier_tangent_vectors(M, B)

returns the tangent vectors at start and end points of the composite Bézier curve
pointing from a control point to the first and last
inner control points for each segment of the composite Bezier curve specified by
the control points [`B`], either a vector of segments of controlpoints.
"""
function getBezierTangentVectors(M::Manifold, B::Array{Array{P,1},1}) where {P}
    return vcat( [ [log(M, b[1], b[2]), log(M, b[end], b[end-1])] for b in B ]...)
end

@doc doc"""
    getBezierJunctionPoints(M,B)

returns the start and end points of the segments of the composite Bézier curve
specified by the control points `B`.
"""
function getBezierJunctionPoints(M::Manifold, B::Array{Array{P,1},1}) where {P}
    return vcat( [ b[1] for b in B ]..., last(last(B)) )
end

@doc doc"""
    getBezierInnerPoints(M,B)

returns the inner (i.e. despite start and end) points of the segments of the
composite Bézier curve specified by the control points `B`.
"""
function getBezierInnerPoints(M::Manifold, B::Array{Array{P,1},1}) where {P}
    return vcat([b[2:end-1] for b in B]... )
end

@doc doc"""
    getBezierPoints(M,B)

returns the control points of the segments of the composite Bézier curve
specified by the control points `B`, either a vector of segments of
controlpoints or a.
"""
function getBezierPoints(M::Manifold, B::Array{Array{P,1},1}) where {P}
    return vcat( [ b[1:end-1] for b in B]..., last(last(B)) )
end