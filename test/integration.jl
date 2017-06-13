let xmin = (-1.0, -1.0, -1.0)
    xmax = ( 1.0,  1.0,  1.0)

    for n = 0:2:10
        @test nintegrate((x,y,z)->x^n, xmin, xmax)[1] ≈ 8/(n+1)
        @test nintegrate((x,y,z)->y^n, xmin, xmax)[1] ≈ 8/(n+1)
        @test nintegrate((x,y,z)->z^n, xmin, xmax)[1] ≈ 8/(n+1)
    end

    @test nintegrate((x,y,z)->x^2*y^2, xmin, xmax)[1] ≈ 8/9
    @test nintegrate((x,y,z)->z^2*y^2, xmin, xmax)[1] ≈ 8/9
    @test nintegrate((x,y,z)->x^2*z^2, xmin, xmax)[1] ≈ 8/9

    @test nintegrate((x,y,z)->x^2*y^2*z^2, xmin, xmax)[1] ≈ 8/27

    ɛ = eps()

    for n = 1:2:11
        @test nintegrate((x,y,z)->x^n, xmin, xmax)[1] < ɛ
    end

    @test nintegrate((x,y,z)->x^2*z^3, xmin, xmax)[1] < ɛ
    @test nintegrate((x,y,z)->x^3*z^2, xmin, xmax)[1] < ɛ

    @test nintegrate((x,y,z)->x^2*y*z, xmin, xmax)[1] < ɛ
    @test nintegrate((x,y,z)->x*y^2*z, xmin, xmax)[1] < ɛ
    @test nintegrate((x,y,z)->x*y*z^2, xmin, xmax)[1] < ɛ

end

let xmin = (0.0, 0.0, 0.0)
    xmax = (1.0, 1.0, 1.0)

    for n = 0:11
        @test nintegrate((x,y,z)->x^n, xmin, xmax)[1] ≈ 1/(n+1)
        @test nintegrate((x,y,z)->y^n, xmin, xmax)[1] ≈ 1/(n+1)
        @test nintegrate((x,y,z)->z^n, xmin, xmax)[1] ≈ 1/(n+1)
    end

    @test nintegrate((x,y,z)->x^2*y^2, xmin, xmax)[1] ≈ 1/9
    @test nintegrate((x,y,z)->z^2*y^2, xmin, xmax)[1] ≈ 1/9
    @test nintegrate((x,y,z)->x^2*z^2, xmin, xmax)[1] ≈ 1/9

    @test nintegrate((x,y,z)->x^2*z^3, xmin, xmax)[1] ≈ 1/12
    @test nintegrate((x,y,z)->x^3*z^2, xmin, xmax)[1] ≈ 1/12
    @test nintegrate((x,y,z)->x^2*y*z, xmin, xmax)[1] ≈ 1/12
    @test nintegrate((x,y,z)->x*y^2*z, xmin, xmax)[1] ≈ 1/12
    @test nintegrate((x,y,z)->x*y*z^2, xmin, xmax)[1] ≈ 1/12

    @test nintegrate((x,y,z)->x^3*y*z, xmin, xmax)[1] ≈ 1/16
    @test nintegrate((x,y,z)->x*y^3*z, xmin, xmax)[1] ≈ 1/16
    @test nintegrate((x,y,z)->x*y*z^3, xmin, xmax)[1] ≈ 1/16

    @test nintegrate((x,y,z)->x^2*y^2*z^2, xmin, xmax)[1] ≈ 1/27

end

let f = (x, y, z) -> x * sin(2y) * cos(3z)

    xmin = (0.0, 0.0, 0.0)
    xmax = (1.0, 1.0, 1.0)

    (I, E, n, R) = nintegrate(f, xmin, xmax)
    @test I == nintegrate(f, R)

    W = weightedpoints(R)
    @test I ≈ nintegrate(f, W)

    W = weightedpoints(NIntegration.idem, R)
    @test I ≈ nintegrate(f, W)
end
