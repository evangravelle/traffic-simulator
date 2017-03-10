% runs MainScript while varying alpha

global alpha

for alpha = linspace(0,40,21)
    run('MainScript')
end