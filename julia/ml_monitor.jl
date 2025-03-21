module MLMonitor
export MLMonitorInstance, MLMonitorJob
export startJob, updateTimingPrediction!, sendJobUpdate, reportJobfinished

using HTTP, JSON
include("./async.jl")
using .Async

"Reference to the remote server that receives monitoring updates."
mutable struct MLMonitorInstance
    url::String
end

mutable struct MLMonitorJob
    ml_monitor::MLMonitorInstance
    run_id::String
    start_time::BigInt
    max_epochs::Int

    epoch::Int
    loss::Union{Float32,Nothing}
    estimated_end_time::Union{BigInt,Nothing} # Milliseconds since epoch
end

MLMonitorJob(ml_monitor::MLMonitorInstance, run_id::String, num_epochs::Int) = MLMonitorJob(ml_monitor, run_id, time() * 1000, num_epochs, 0, nothing, nothing)

function startJob(ml_monitor::MLMonitorInstance, run_id::String, model_name::String, num_epochs::Int)::MLMonitorJob
    async(() ->
        HTTP.post(ml_monitor.url * "start-job",
            headers=Dict("Content-Type" => "application/json"),
            body=JSON.json(Dict(
                "jobId" => run_id,
                "modelName" => model_name,
                "maxEpochs" => num_epochs
            ))
        ))
    return MLMonitorJob(ml_monitor, run_id, num_epochs)
end

"Predicts estimated end of job based on average time per epoch. Call this at the end of each epoch."
function updateTimingPrediction!(job::MLMonitorJob)
    nowMs = BigInt(time() * 1000)
    timeElapsed = nowMs - job.start_time
    timePerEpoch = timeElapsed / job.epoch
    job.estimated_end_time = job.start_time + round(BigInt, timePerEpoch * job.max_epochs)
end

function sendJobUpdate(job::MLMonitorJob)
    async(() ->
        HTTP.put(job.ml_monitor.url * "progress-report",
            headers=Dict("Content-Type" => "application/json"),
            body=JSON.json(Dict(
                "runId" => job.run_id,
                "epoch" => job.epoch,
                "loss" => job.loss,
                "estEndTime" => job.estimated_end_time
            ))
        ))
end

function reportJobfinished(job::MLMonitorJob)
    async(() ->
        HTTP.post(job.ml_monitor.url * "job-done",
            headers=Dict("Content-Type" => "application/json"),
            body=JSON.json(Dict("runId" => job.run_id))
        ))
end

end