from Levenshtein import distance

def cer(reference, prediction):
    if not reference:
        return 0.0 if not prediction else 1.0
    return distance(reference, prediction) / len(reference)

def wer(reference, prediction):
    ref = reference.split()
    hyp = prediction.split()
    if not ref:
        return 0.0 if not hyp else 1.0

    dp = list(range(len(hyp) + 1))
    for i, r in enumerate(ref, 1):
        new = [i]
        for j, h in enumerate(hyp, 1):
            cost = 0 if r == h else 1
            new.append(min(
                new[-1] + 1,
                dp[j] + 1,
                dp[j - 1] + cost
            ))
        dp = new
    return dp[-1] / len(ref)

def evaluate_pairs(pairs):
    cers, wers, exact = [], [], []
    for ref, pred in pairs:
        cers.append(cer(ref, pred))
        wers.append(wer(ref, pred))
        exact.append(ref.strip() == pred.strip())
    return {
        "CER": sum(cers) / max(1, len(cers)),
        "WER": sum(wers) / max(1, len(wers)),
        "character_accuracy": 1 - sum(cers) / max(1, len(cers)),
        "word_accuracy": 1 - sum(wers) / max(1, len(wers)),
        "exact_sequence_accuracy": sum(exact) / max(1, len(exact)),
        "samples": len(pairs),
    }
